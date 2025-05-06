
proc clean_workspace {} {
    file delete -force ./work
    file delete -force ./modelsim.ini
    file delete -force ./vsim.wlf
    file delete -force ./coverage.ucdb
    file delete -force ./waves.vcd
    puts "Рабочая область очищена."
}

proc create_library {} {
    vlib work
    vmap work work
    puts "Библиотека 'work' создана."
}

proc compile_sources {} {
    set src_files [list \
        "./src/ExpressionCalculator.vhd" \
        "./test/ExpressionCalculator_tb.vhd" \
    ]

    foreach src_file $src_files {
        if {[file exists $src_file]} {
            if {[catch {vcom -93 -work work $src_file} result]} {
                puts "Ошибка при компиляции файла: $src_file"
                puts "Подробности: $result"
                return -code error
            } else {
                puts "Скомпилирован файл: $src_file"
            }
        } else {
            puts "Ошибка: Файл не найден: $src_file"
            return -code error
        }
    }
}

proc run_simulation {} {
    set top_module "ExpressionCalculator_tb"
    set simulation_time "10 us"
    if {[catch {vsim -voptargs=+acc $top_module} result]} {
        puts "Ошибка при запуске симуляции: $result"
        return -code error
    }

    add wave -position insertpoint sim:/ExpressionCalculator_tb/*
    puts "Добавлены сигналы в waveform."

    run $simulation_time
    puts "Симуляция завершена за $simulation_time."
}

proc main {} {
    puts "Начало процесса сборки и симуляции..."

    if {[catch {clean_workspace} result]} {
        puts "Ошибка при очистке рабочей области: $result"
        return
    }

    if {[catch {create_library} result]} {
        puts "Ошибка при создании библиотеки: $result"
        return
    }

    if {[catch {compile_sources} result]} {
        puts "Ошибка при компиляции исходных файлов: $result"
        return
    }

    if {[catch {run_simulation} result]} {
        puts "Ошибка при запуске симуляции: $result"
        return
    }

    puts "Процесс завершен."
}
main