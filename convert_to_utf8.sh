DIRECTORY="LAB-1"

for file in $(ls $DIRECTORY/*.s)
do
   iconv -f WINDOWS-1252 -t UTF-8 "$file" > "CONVERTED/$file"
done