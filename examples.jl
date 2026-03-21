using CSV, DelimitedFiles, DataFrames

x = [0:0.1:10;] # массив [0, 0.1, 0.2 .... 9.8, 9.9, 10.0]
y = sin.(x) .* cos.(x) # поэлементные опперации над массивами пишутся с помощью . (broadcast)

function calculate_y(x) # определим функцию
    return sin(x) * cos(x) # return писать не обязательно, можно просто закончить функцию sin(x) * cos(y)
                           # так как по умолчанию функция возвращает результат своей последней строчки
end

y = calculate_y.(x) # broadcast работает для любой функции

# запись в файл
open("example.txt", "w") do io
    writedlm(io, hcat(x, y)) # записывает матрицу [x_1 y_1
                             #                     x_2 y_2
                             #                     ... ...] в файл example.txt
end

#чтение файла
data = readdlm("example.txt")

#создание DataFrame. Это удобный формат данных для работы с таблицами 
data_df = DataFrame(data, ["x", "y"])
# data_df.x[5] = data_df[5, :x] = data_df[5, "x"] --- синтаксис работы с DataFrame

# запись и чтение CSV
CSV.write("example.csv", data_df)
data_df = DataFrame(CSV.File("example.csv")) # названия колонок считываются из csv файла