using CSV, DelimitedFiles, DataFrames

function read_tess_response_function(tess_response_function_name) # считывает response function фильтра телескопа TESS

    df = DataFrame(CSV.File(tess_response_function_name)) # из файла tess_resp..
    new_wav = df.wavelength.*10 # поэлементно
    response_val= df." response"
    res = DataFrame(wavelength = new_wav, response = response_val)
    return res
end

# пусть колонки называются "wavelength", "ed_flux", "continuum_ed_flux" 
# (ed_flux --- "эддингтоновский поток", поток / 4π)

function process_bosz_data(wave_file_name, flux_file_name) # считыывает длины волн и потоки и перезаписывает в один csv файл, длины волн в bosz..., потоки в mp...
    # сначала считайте файл в DataFrame, затем сохраните его в csv
    
    wavelength =vec(readdlm(wave_file_name)) # тк датафрейм ожидает ветор, а если просто прочитать создастся массив
    # wavelength = readdlm(wave_file_name)[:,1]
    flux_m = readdlm(flux_file_name) # тут 2 столбца, vec не подходит
    ed_flux = flux_m[:, 1] # все строки, колонка 1
    continuum_ed_flux = flux_m[:,2]
    # ed_flux, continuum_ed_flux = flux_m[:,1], flux_m[:,2]
    bosz_df = DataFrame(wavelength = wavelength, ed_flux = ed_flux, continuum_ed_flux = continuum_ed_flux)
    CSV.write("processed_bosz.csv", bosz_df)
    return bosz_df
end


function find_tess_ed_flux(bosz_df, tess_response_df) # для нахождения ed_flux с помощью линейной интеполяции на длины волн bosz
    
    # данные
    bosz_wave = bosz_df.wavelength
    bosz_flux= bosz_df.ed_flux
    tess_wave = tess_response_df.wavelength
    tess_resp = tess_response_df.response
    result=0.0
    
    # интерполяция( для каждой длины волны найти response)
    n_bosz = length(bosz_wave)
    tess_interpolation = zeros(n_bosz) # массив нулей, для x вне диапазона tess_wave значения нулевые
    for i in 1:n_bosz
	x= bosz_wave[i] # текущая длина волны

	j=1 # сюда сохраняем найденный k, индекс левой границы интервала где лежит х
	for k in 1:length(tess_wave)-1
		if tess_wave[k]<= x <= tess_wave[k+1]
		j=k
	break 
		end
	end
	
	#линейная интерполяция, х1 у1 левая точка
	
	x1=tess_wave[j]
	y1=tess_resp[j]
	x2=tess_wave[j+1]
	y2=tess_resp[j+1]
	
	y= y1 + (y2-y1) * (x- x1)/(x2- x1)
	
	tess_interpolation[i]= y
    end
    
    #интеграл, метод трапеций
    f = bosz_flux .*tess_interpolation # подынтегральная ф
    for i in 1:n_bosz-1
    step= bosz_wave[i+1] - bosz_wave[i]
    result += ((f[i]+f[i+1])/2 )*step
    end
    return result
	
end

tess_response_df = read_tess_response_function("tess-response-function-v2.0.csv")
bosz_df = process_bosz_data("bosz2024_wave_r500.txt", "mp_t5000_g+5.0_m+0.00_a+0.00_c+0.00_v0_r500_resam.txt")
tess_ed_flux = find_tess_ed_flux(bosz_df, tess_response_df)

# вычисление потока в сериях
function flux_in_range(bosz_df, tess_response_df, w_min, w_max)
    idx_min = findfirst(bosz_df.wavelength .>= w_min)
    idx_max = findlast(bosz_df.wavelength .<= w_max)
    
    if isnothing(idx_min) || isnothing(idx_max)
            return 0.0
    end
    
    cropped_df = DataFrame(
        wavelength = bosz_df.wavelength[idx_min:idx_max],
        ed_flux = bosz_df.ed_flux[idx_min:idx_max],
        continuum_ed_flux = bosz_df.continuum_ed_flux[idx_min:idx_max]
    )
    
    return find_tess_ed_flux(cropped_df, tess_response_df)
end

# cерии водорода
series_list = [
    ("Лайман", 912.0, 3646.0),
    ("Бальмер", 3646.0, 8204.0),
    ("Пашен", 8204.0, 14588.0),
    ("Брекет", 14588.0, 22790.0),
    ("Пфунд", 22790.0, 32820.0),
]

# линии Бальмера
function line_flux(bosz_df, tess_response_df, center, half_width=15)
    return flux_in_range(bosz_df, tess_response_df, center-half_width, center+half_width)
end

balmer_lines = [
    ("Ha", 6560.73),
    ("Hb", 4861.3),
    ("Hy", 4340.5),
    ("Hd", 4101.7),
]


for (name, center) in balmer_lines
    flux = line_flux(bosz_df, tess_response_df, center)
    println("$name: $flux ")
end

for (name, w_min, w_max) in series_list
    flux = flux_in_range(bosz_df, tess_response_df, w_min, w_max)
    println("$name: $flux")
end



open("result.txt", "w") do io
    println(io, "Eddington flux in TESS band: $tess_ed_flux")
 for (name, center) in balmer_lines
        flux = line_flux(bosz_df, tess_response_df, center)
        println(io, "$name: $flux")
    end
        for (name, w_min, w_max) in series_list
        flux = flux_in_range(bosz_df, tess_response_df, w_min, w_max)
        println(io, "$name ($w_min - $w_max): $flux")
    end
end

println("Eddington flux in TESS band: $tess_ed_flux")
