using CSV, DelimitedFiles, DataFrames
using Makie, GLMakie

# напишите функцию, считывающую response function фильтра телескопа TESS
function read_tess_response_function(tess_response_function_file_name)
    # длина волны в файле указана в нанометрах, переведите в ангстремы
    # функция должна вернуть DataFrame
end

# напишите функцию, считывающую из файлов длины волн и потоки и перезаписывающую их в один csv файл
# пусть колонки называются "wavelength", "ed_flux", "continuum_ed_flux" 
# (ed_flux --- "эддингтоновский поток", поток / 4π)
function process_bosz_data(wave_file_name, flux_file_name)
    # сначала считайте файл в DataFrame, затем сохраните его в csv
    # функция должна вернуть DataFrame
end

# напишите функцию для нахождения эингтоновского потока в фильтре TESS
# (см. прилагаемый pdf файл). для этого линейно интерполируйте response function на длы волн bosz
function find_tess_ed_flux(bosz_df, tess_response_df)
    # функция вовращает число 
end



tess_response_df = read_tess_response_function("tess-response-function-v2.0.csv")
bosz_low_resolution_df = process_bosz_data("bosz2024_wave_r500.txt", "mp_t5000_g+5.0_m+0.00_a+0.00_c+0.00_v0_r500_resam.txt")
bosz_high_resolution_df = process_bosz_data("bosz2024_wave_r20000.txt", "mp_t5000_g+5.0_m+0.00_a+0.00_c+0.00_v0_r20000_resam.txt")

tess_ed_flux = find_tess_ed_flux(bosz, tess_response_df)
println("Eddington flux in TESS band: $tess_ed_flux")