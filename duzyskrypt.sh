#!/bin/bash

# Author: Yevhenii Kasian
# Created on: 12.06.2022
# Version: 1.0
# Description: Aplikacja pomaga zorganizować każdy trening poprzez stworzenie listy cwiczen zrobienia. Pozwala również obliczyć swoje BMI, ustalić plan treningowy na dany dzień, czy też sprawdzić liczbę spalonych kalorii.

trainer="Twoj TrainingHelper"

yad --info --text="\n<span font='12'>Ta aplikacja ma Ci pomóc w uporządkowaniu Twojego treningu lub cwiczenia i nie zapomnieć o niczym.</span>" \
--title="Twoj TrainingHelper" --width 250 --image="images.png" --text-align="center" --button=OK:0

name=$(zenity --entry --title "Twoj TrainingHelper" --text "Wpisz imie : "  --height 120)
if test -z $name 
then
    zenity --error --text "Musisz wpisac imie ."
    exit
fi

generate_panel() {
    case "$1" in
	"Glowne" )
		info="Hej <span foreground='blue'>$name</span>!!\n\n<span><i>Wybierz jedna z dostepnych opcij.</i></span>\n";;
	"Trening" )
		info="\nStworz swoja liste treningow\n";;
	"fit")
		if [[ ${BMI%%.*} -eq 0 ]]; then
			info="Stay fit:\n\n BMI: $BMI\n\n <span foreground='blue'>Cwiczenia:</span> $exercises\n"
		elif [[ ${BMI%%.*} -gt 0 && ${BMI%%.*} -le 18 ]]; then
			info="Stay fit:\n\n BMI: $BMI \n <span foreground='red'>Masz niedowage!</span>\n\n <span foreground='blue'>Exercises:</span> $exercises\n"
		elif [[ ${BMI%%.*} -gt 18 && ${BMI%%.*} -le 25 ]]; then
			info="Stay fit:\n\n BMI: $BMI \n <span foreground='green'>Twoja waga jest dobra.</span>\n\n <span foreground='blue'>Exercises:</span> $exercises\n"
		elif [[ ${BMI%%.*} -gt 25 ]]; then
			info="Stay fit:\n\n BMI: $BMI \n <span foreground='red'>Masz nadwage!</span>\n\n <span foreground='blue'>Exercises:</span> $exercises\n"
		fi;;
	"dates")
		info="Kalendarz cwiczen";;
	*) echo "Wrong arguments!!";;
    esac
}

menu=("1.Planuj trening" "2.Traning_calculator" "3.Kalendarz cwiczen")
menuTrening=("1.Dodaj cwiczenie" "2.Usun cwiczenie" "3.Zmien liczbe podajsc" "4.Pokaz liste" "5.Usun liste.")
menuStayFit=("1.Licz BMI" "2.Wybierz cwicenia na dzisiaj" "3.Licz spalone kalorii")
i=0
nameOfCwicz=()
numberOfCwicz=()
powtor=()
sum=0
BMI=0
weight=0
arr=()
x=1
exercises="none"
index=${#nameOfCwicz[@]}

while true; do
	generate_panel "Glowne"
	options=$(zenity --list --height 360 --title="Twoj TrainingHelper" --text="$info" --cancel-label "Wyjscie" --ok-label "Wybierz" --column="Main menu" "${menu[@]}")
	if [[ $? -eq 1 ]]; then
	    zenity --question --text="Czy napewno chcesz wyjsc ?"
	    if [[ $? -eq 0 ]]; then
	    	echo "Koniec !"
	    	break
	    fi
	fi

	case "$options" in
		"${menu[0]}" )
			while true; do
				generate_panel "Trening"
				optionZero=$(zenity --list --height 360 --title="Trening list" --text="$info" --cancel-label "Main menu" --ok-label "Choose" \
					--column="Menu" "${menuTrening[@]}" --width 150)
				
				if [[ $? -eq 1 ]]; then
					break
				fi

				case "$optionZero" in
					"${menuTrening[0]}" )
						index=$((${#powtor[@]}))
						howmany=$(zenity --scale --title="Ile czwiczen chcesz dodac ?" --text="Liczba " --min-value 0 --max-value 20 value 2)
						for (( y=0; y<howmany; y++ )); do
							nameOfCwicz=$(zenity --entry --title="Nazwa czwiczenia" --text="Wpisz nazwe czwiczenia")
							numberOfCwicz[$index+$y]=$(zenity --scale --text="Wpisz liczbe podejsc" --title="Liczba podejsc" --min-value 0 \
								--max-value 20 value 0)
							res="cwiczenie: ${numberOfCwicz[$index+$y]}x$nameOfCwicz"
							powtor[$index+$y]=$(zenity --entry --title="Wpisz liczbe powtorzen" --text="Liczba powtorzen:")
							res="cwiczenie: ${numberOfCwicz[$index+$y]} x $nameOfCwicz x ${powtor[$index+$y]}"
							if ! [[ ${powtor[$index+$y]} =~ ^[0-9]{1,4}$ ]]; then
								zenity --error --text="Wrong data!"
								new_arr=()
								unset numberOfCwicz[$toRemove-1]
								unset powtor[$toRemove-1]
								for i in ${!numberOfCwicz[@]}; do
									new_arr+=( "${numberOfCwicz[i]}" )
								done
								numberOfCwicz=("${new_arr[@]}")
								unset new_array
						
								new_arr1=()
								for i in ${!powtor[@]}; do
									new_arr1+=( "${powtor[i]}" )
								done
								powtor=("${new_arr1[@]}")
								unset new_arr1
								break
							else
								echo $res >> training.txt
								sum=$(($sum+(${numberOfCwicz[$index+$y]}*${powtor[$index+$y]})))
								echo "cwiczenie dodano."
							fi
						done
						if [[ -e training.txt ]]; then
							grep "cwiczenie" training.txt > tmpfile
							mv tmpfile training.txt
							cut -f2 -d "." training.txt > tmp
							nl -s "." tmp > tmp1
							mv tmp1 training.txt
							rm tmp	
							#echo "   sum: $res" >> training.txt
						fi;;
					"${menuTrening[1]}" )
						if ! [[ -e training.txt ]]; then
							zenity --warning --text="Jeszcze nie stworzyles treningu."
							break
						fi
						toRemove=$(zenity --scale --title="Wpisz numer cwiczenia do usuniecia" --text="Numer" --min-value 0 \
						--max-value ${#powtor[@]} --step 1)
						sum=$(($sum-(${numberOfCwicz[$toRemove-1]}*${powtor[$toRemove-1]})))
						sed "${toRemove}d" training.txt > tmp
						mv tmp training.txt
						grep "Cwiczenie" training.txt > tmpfile
		 				mv tmpfile training.txt
						cut -f2 -d "." training.txt > tmp
						nl -s "." tmp > tmp1
						mv tmp1 training.txt
						rm tmp
						#echo "   sum: $sum" >> training.txt

						new_arr=()
						unset numberOfCwicz[$toRemove-1]
						unset powtor[$toRemove-1]
						for i in ${!numberOfCwicz[@]}; do
							new_arr+=( "${numberOfCwicz[i]}" )
						done
						numberOfCwicz=("${new_arr[@]}")
						unset new_array
						
						new_arr1=()
						for i in ${!powtor[@]}; do
							new_arr1+=( "${powtor[i]}" )
						done
						powtor=("${new_arr1[@]}")

						unset new_arr1
						echo "Cwiczenie usunieto !";;
					"${menuTrening[2]}" )
						if ! [[ -e training.txt ]]; then
							zenity --warning --text="Jeszcze nie stworzyles treningu."
							break
						fi
						cat training.txt
						toChange=$(zenity --scale --text="Wpisz numer cwiczenia do zmiany liczby podejsc" --min-value 0 --max-value ${#powtor[@]} \
						--step 1)
						Name=$(zenity --entry --text="Wpisz nazwe cwiczenia")
						res="${numberOfCwicz[$toChange-1]}x${Name}"

						if grep --quiet "$res" training.txt ; then #--quiet, zeby sie nie wyswietlaly powiadomoenia ze znaleziono
							value=$(zenity --scale --text="Zmieniasz z ${numberOfCwicz[$toChange-1]} na:" \
							--min-value 0 --max-value 20 --value 0)	
							res1="${value}x${Name}"

							if [[ $value -lt ${numberOfCwicz[$toChange-1]} ]]; then
								dif=$((${powtor[$toChange-1]}*(${numberOfCwicz[$toChange-1]}-$value)))
								sum=$(($sum-$dif))
								sed -i -e 's/'$res'/'$res1'/g' training.txt #podmiana danych
								grep "cwiczenie" training.txt > tmpfile
								mv tmpfile training.txt
								cut -f2 -d "." training.txt > tmp
								nl -s "." tmp > tmp1
								mv tmp1 training.txt
								rm tmp	
								#echo "   sum: $sum" >> training.txt
								numberOfCwicz[$toChange-1]=$(($value))
							elif [[ $value -gt ${numberOfCwicz[$toChange-1]} ]]; then
								dif=$((($value-${numberOfCwicz[$toChange-1]})*${powtor[$toChange-1]}))
								sum=$(($sum+$dif))
								numberOfCwicz[$toChange-1]=$(($value))
								sed -i -e 's/'$res'/'$res1'/g' training.txt
								grep "Cwicz" training.txt > tmpfile
								mv tmpfile training.txt
								cut -f2 -d "." training.txt > tmp
								nl -s "." tmp > tmp1
								mv tmp1 training.txt
								rm tmp	
								#echo "   sum: $sum" >> training.txt
							fi
						else
							zenity --warning --text="Wrong data"
						fi;;
					"${menuTrening[3]}" )
						if [[ -e training.txt ]]; then
							zenity --text-info --filename="training.txt"
						else
							zenity --error --title="Uwaga" --text="NIE STWORZONE TRENINGU !"
						fi;;
					"${menuTrening[4]}" )
						if [[ -e training.txt ]]; then
							rm training.txt
							sum=0
							numberOfCwicz=()
							powtor=()
							zenity --info --text="Plik usunieto"
						else
							zenity --error --title="Uwaga" --text="NIE STWORZONE TRENINGU !"
						fi;;
				esac
			done;;
		"${menu[1]}" )
			while true; do
				
				generate_panel "fit"
				optionOne=$(zenity --list --height 360 --title="Stay_fit" --text="$info" --cancel-label "Main menu" --ok-label "Wybrac" --column="Menu" "${menuStayFit[@]}")
				if [[ $? -eq 1 ]]; then
					break
				fi
				case "$optionOne" in
					"${menuStayFit[0]}" )
						height=$(zenity --entry --text="Wpisz swoj wzrost:" --title="wzrost w metrach")
						if [[ $height > 1 ]]; then
						#$height =~ ^[1-4]{1}.[0-9]{2}
							weight=$(zenity --scale --text "Waga: " --value 93 --step 1 --min-value 0 --max-value 200)
							BMI=`echo "scale=2;$weight/$height/$height" | bc -l`
						else
							zenity --warning --text="Wrong data"	
						fi
						;;
					"${menuStayFit[1]}" )
						exercises=$(zenity --list --checklist --height 200 --width 300 --column=" " --column="Typ treningu" " 10min brzuch " " 10min nogi " \
					       	" 10min ramiona" " 10min arms " " 10min nogi " " 40/50min full_body workout " " 40/50min trening \
						na nogi " " 40/50min uda ")
						echo "Cwiczenie na dzisiaj:$exercises" >> toDo.txt;;
					"${menuStayFit[2]}" )
						activity=$(zenity --list --radiolist --width 300 --height 300 --column=' ' --column=type TRUE Rower FALSE Aerobik FALSE Joga \
						FALSE Koszykowka FALSE Pilka)
						case "$activity" in
							"Rower" )
								time=$(zenity --scale --text="czas" min-value 0 max-value 5 value 0 --title="Czas w minutach")
								if [[ $weight -eq 0 ]]; then
									weight=$(zenity --scale --title="Waga" --text="Wpisz wage" --min-value 20 --max-value 200 --value 60)
								fi
								burned=`echo "scale=2;$weight*7.5*$time/60" | bc -l`
								zenity --info --text="Spalono $burned kcal" --width 200;;
							"Aerobik" )
								time=$(zenity --scale --text="czas" min-value 0 max-value 5 value 0 --title="Czas w minutach")
								if [[ $weight -eq 0 ]]; then
									weight=$(zenity --scale --title="Waga" --text="Wpisz Wage" --min-value 20 --max-value 200 --value 60)
								fi
								burned=`echo "scale=2;$weight*7.3*$time/60" | bc -l`
								zenity --info --text="Spalono $burned kcal" --width 200;;

							"Joga" )
								time=$(zenity --scale --text="czas" min-value 0 max-value 5 value 0 --title="Czas w minutach")
								if [[ $weight -eq 0 ]]; then
									weight=$(zenity --scale --title="Waga" --text="Wpisz wage" --min-value 20 --max-value 200 --value 60)
								fi
								burned=`echo "scale=2;$weight*7*$time/60" | bc -l`
								zenity --info --text="Spalono $burned kcal" --width 200;;

							"Koszykowka" )
								time=$(zenity --scale --text="czas" min-value 0 max-value 5 value 0 --title="Czas w minutach")
								if [[ $weight -eq 0 ]]; then
									weight=$(zenity --scale --title="Waga" --text="Wpisz wage" --min-value 20 --max-value 200 --value 60)
								fi
								burned=`echo "scale=2;$weight*6.5*$time/60" | bc -l`
								zenity --info --text="Spalono $burned kcal" --width 200;;

							"Pilka" )
								time=$(zenity --scale --text="czas" min-value 0 max-value 5 value 0 --title="Czas w minutach")
								if [[ $weight -eq 0 ]]; then
									weight=$(zenity --scale --title="Waga" --text="Wpisz wage" --min-value 20 --max-value 200 --value 60)
								fi
								burned=`echo "scale=2;$weight*8*$time/60" | bc -l`
								zenity --info --text="Spalono $burned kcal" --width 200;;

						esac;;
				esac
			done;;
		"${menu[2]}" )
			dates=$(zenity --forms --title="Dodaj cwiczenie" --text="Wpisz info." --separator=", " --add-entry "Opis:" --add-entry "Gdzie" \
			--add-calendar "Kiedy")
			echo "Cwiczenie | Gdzie | Data: $dates" >> wydarzenia.txt
			echo "Wydarzenie zapisano w pliku wydarzenia.txt";;

	esac
done




