#!/bin/bash
####
# EK5 - 2010
#############
# Convert jpeg to pdf
######################

echo "Jpeg to Pdf Script converter by EK5"
echo

# Controllo errori input

error() {
 echo "Usage: [Number of jpeg] [Pdf name]"
 echo "Creates a PDF every X Jpegs"
 echo "The images must be in the same directory where the script is running!"
 echo
 exit
}

if [ -z $1$2 ] ; then error ; fi

if [ -z $1 ] ; then
  echo "The number of images for PDF is missing!"
  echo
  error
fi

if [ $1 -le 0 ] ; then 
  echo "Invalid number of images!"
  echo
  error
fi

if [ -z $2 ] ; then
 echo "The PDF filename is missing!"
 echo
 error
fi

IFS="" ; 
num=0 ;    # Esplicito le variabili
nfile=1 ;

#for file in `ls -1b *.jpg` ;  Naaaa... non usiamo FOR...

while read file  ;  # Acquisisco e ordino i file con una NAMED PIPE (in fondo con DONE)
                    # e con un ciclo WHILE scrivo sulla variabile 
 do 
 
  declare -a files  # Creo un array

  let num++         # Aggiorno il contatore

  files[$num]="$file" ;  		# Concateno i nomefile

  if [ $num = $1 ] ; then               # Quando arriva al numero desiderato converte le prime n immagini

     echo Converting ${files[@]} into $2.$nfile.pdf ... ;
     convert ${files[@]} $2.$nfile.pdf > /dev/null ;
     if [ $? != 0 ] ; then error ; fi   

     let nfile++ ;

     unset files ;   			# Flush variabili
     num=0 ;

  fi

done < <( ls -1b *.jpg | sort -V )      # NAMED PIPE

echo Converting ${files[@]} into $2.$nfile.pdf ... ;
convert ${files[@]} $2.$nfile.pdf > /dev/null 			# Converte i rimanenti
if [ $? != 0 ] ; then error ; fi   
#EOF

