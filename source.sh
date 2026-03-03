#!/bin/bash

# FUNCȚII PENTRU MENIUL DE PRELUCRARE A STRUCTURILOR DE DATE

# Funcția de citire a tuturor valorilor unui tag
read_tag(){
    local file=$1
    local tag=$2
    echo "Toate valorile pentru <$tag>:"
    grep -oP "(?<=<$tag>).*?(?=</$tag>)" "$file"
}

read_element() {
    local file=$1
    local main_tag=$2
    local attribute=$3
    local value=$4

    awk -v tag="$main_tag" -v attr="$attribute" -v val="$value" '
    BEGIN { found = 0 }
    {
        gsub(/^[ \t]+|[ \t]+$/, "")
    }
    $0 ~ "<" tag ">" {
        found = 0
        buffer = ""
    }
    found == 0 && $0 ~ "<" attr ">" val "</" attr ">" {
        found = 1
    }
    found == 1 {
        buffer = buffer "\n" $0
        if ($0 ~ "</" tag ">") {
            print gensub(/^[ \t]+|[ \t]+$/, "", "g", buffer)
            exit
        }
    }' "$file" | awk -F'[<>]' '!/<[^\/]/ {next} {print $3}'
}

# Funcția de creare a unui fișier XML nou
add_file() {
    local file=$1
    if [[ -z "$file" ]]; then
        echo "Eroare: Nu ați introdus niciun nume de fișier."
        return 1
   fi

    cat <<EOF > "$file"
<?xml version="1.0" encoding="UTF-8"?>
EOF

    echo "A fost creat un fișier XML nou: $file"
}

# Funcție pentru a adăuga un element într-un fișier XML
add_element() {
    local file="$1"
    local element_tag="$2"
    local attribute_tag="$3"
    local content="$4"

    if [[ ! -f "$file" ]]; then
        echo "Eroare: Fișierul $file nu există!"
        return 1
    fi

    local root_tag=$(grep -oP '(?<=<)[^/?> ]+' "$file" | head -1)
    if [[ -z "$root_tag" ]]; then
        echo "Eroare: Nu s-a găsit un tag rădăcină valid în $file!"
        return 1
    fi

    local new_element="  <$element_tag>
    <$attribute_tag>$content</$attribute_tag>
  </$element_tag>"

    local tmp_file=$(mktemp)
    awk -v root="</$root_tag>" -v element="$new_element" '
        $0 ~ root { print element }
        { print $0 }
    ' "$file" > "$tmp_file"

    if mv "$tmp_file" "$file"; then
        echo "Succes: Elementul a fost adăugat în $file."
    else
        echo "Eroare: Nu s-a putut actualiza $file!"
        rm -f "$tmp_file"
        return 1
    fi
}

# FUNCȚII PENTRU PRELUCRAREA DATELOR DINTR-O APLICAȚIE

# Funcție pentru a extrage valoarea unui anumit tag
extract_tag() {
  local xml="$1"
  local tag="$2"
  echo "$xml" | grep -oP "<$tag>(.*?)</$tag>" | sed -e "s|<$tag>||" -e "s|</$tag>||"
  echo ""
}

# Funcție pentru a extrage valoarea unui atribut
extract_attribute() {
  local xml="$1"
  local tag="$2"
  local attr="$3"
  echo "$xml" | grep -oP "<$tag [^>]*$attr=\"[^\"]*\"" | sed -e "s|.*$attr=\"||" -e "s|\".*||"
}

# FUNCTIILE PENTRU MENIUL SECUNDAR DE PROCESARE A STRUCTURILOR DE DATE

meniu1(){
    echo ""
    echo "Parsarea fișierelor XML - structuri de date"
    echo "1. Citește un tag"
    echo "2. Citește un element"
    echo "3. Creează un fișier XML nou"
    echo "4. Adaugă un element nou într-un fișier XML deja existent"
    echo "5. Ieșire"
    echo -n "Alegeți o opțiune: "
    echo ""
}

apel_meniu1(){
    while true; do
        meniu1
        read optiune

        case $optiune in
            1)
                echo -n "Introduceți numele fișierului XML: "
                read file
                echo -n "Introduceți numele tagului de citit: "
                read tag
                read_tag "$file" "$tag"

                echo -n "Doriți să vă întoarceți la meniu? (y/n): "
                read reluare
                [[ "$reluare" != "y" ]] && break
                ;;

            2)
                echo -n "Introduceți numele fișierului XML: "
                read file
                echo -n "Introduceți tag-ul elementului: "
                read element_tag
                echo -n "Introduceți tag-ul primului atribut al elementului: "
                read element_atr
                echo -n "Introduceți valoarea atributului elementului căutat: "
                read atr_value
                read_element "$file" "$element_tag" "$element_atr" "$atr_value"

                echo -n "Doriți să vă întoarceți la meniu? (y/n): "
                read reluare
                [[ "$reluare" != "y" ]] && break
                ;;

            3)
                echo -n "Introduceți numele fișierului XML pe care doriți să îl creați: "
                read file
                add_file "$file"
                echo "<root>" > "$file"
                echo "</root>" >> "$file"
                echo -n "Fișierul XML cu numele <$file> a fost creat cu succes!"

                echo -n "Doriți să vă întoarceți la meniu? (y/n): "
                read reluare
                [[ "$reluare" != "y" ]] && break
                ;;

            4)
                echo ""
                echo -n "Introduceți numele fișierului XML: "
                read file
                echo -n "Introduceți tagul elementului: "
                read element_tag
                echo -n "Introduceți tagul primului atribut al elementului: "
                read element_atr
                echo -n "Introduceți conținutul dintre taguri: "
                read content

                add_element "$file" "$element_tag" "$element_atr" "$content"

                echo -n "Doriți să vă întoarceți la meniu? (y/n): "
                read reluare
                if [[ "$reluare" != "y" ]]; then
                    break
                fi
                ;;

            5)
                echo "La revedere!"
                exit 0
                ;;

            *)
                echo "Opțiune invalidă!"
                ;;
        esac
    done
}

# MENIUL PRINCIPAL

    echo ""
    echo "-------PROIECT Instrumente și Tehnici de Bază în Informatică-------"
    echo "------------Titlu proiect: Parsarea fișierelor XML------------"
    echo "-------------------- 2024-2025 --------------------"
    echo ""
    echo "Echipa: Spice Girls   Studenți:"
    echo "Martole Ilinca-Maria"
    echo "Plesca Maria-Erika"
    echo "Virghileanu Maria-Roberta"
    echo ""
    echo "Ce tip de date doriți să parsați?"
    echo "1. Structuri de date dintr-un fișier XML"
    echo "2. Date dintr-o aplicație"
    echo "Alegeți opțiunea: "

    read optiune_meniu

    case $optiune_meniu in
    1) 
    apel_meniu1
    ;;
    2) 
    echo "Funcționalitatea pentru date dintr-o aplicație nu este încă implementată."
    ;;
    *) 
    echo "Opțiune invalidă!"
    ;;
    esac



