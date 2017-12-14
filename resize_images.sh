#!/bin/bash
# Script para renomear/redimensionar imagens

# Recebe nome do diretório que contém as imagens a serem editadas
dir=$1
# Renomear diretório (ou não)
echo "Diretório a ser trabalhado:" $dir
while true; do
    read -p "O diretório tem nome padrão (NomeDoLugar-YYYYmes)?" sn
    case $sn in
        [Ss]* ) echo "Iniciando script..."; break;;
        [Nn]* ) echo "Renomeie o diretório e execute novamente o script, alterando o argumento de entrada"; exit;;
        * ) echo "Responder (s)im ou (n)ao.";;
    esac
done
cd $dir

# Substituir espaços em branco por underlines
rename 'y/ /_/' *

# Iniciar contador
cont=0
# Loop para listar arquivos (se quiser em ordem inversa, acrescentar parâmetro "-r" no ls abaixo)
for original in $(ls | egrep '\.jpg$|\.JPG$|\.jpeg$|\.gif$|\.GIF$|\.png$|\.PNG$'); do
	echo $original
	# Obter nome e extensão
	nome=$(echo $original | rev | cut -d"." -f2-  | rev)
	ext=$(echo $original | awk -F"." '{print $NF}')
	
	# Caso tenha compressão JPG, mudar extensão de JPG/jpeg para jpg (se for o caso)
	if [ "$ext" == "JPG" ] || [ "$ext" == "jpeg" ]; then
		#echo "Mudando extensão"
		ext='jpg'
		novo_nome1=$nome'.'$ext
		mv $original $novo_nome1
	else
		#echo "Sem mudança de extensão"
		novo_nome1=$original
	fi
	
	# Mudar nome do arquivo para padrão com base no nome do diretório
	lugar=$(echo $dir | awk -F"-" '{print $1}')
	# Número de dígitos (acrescenta zeros à esquerda)
	ndigitos=3
	contador=$(printf "%0*d\n" $ndigitos $cont)
	novo_nome2=$contador'-'$lugar'.'$ext
	echo "Mudando nome para" $novo_nome2
	mv $novo_nome1 $novo_nome2
	nome_arq=$novo_nome2
	
	# Redimensionar imagem se largura (ou altura) for maior que 800 px
	largura=$(convert $nome_arq -print "%w" /dev/null)
	altura=$(convert $nome_arq -print "%h" /dev/null)
	#convert $nome_arq -print "Tamanho original: %wx%h\n" /dev/null
	if [ "$largura" -gt "800" ] || [ "$altura" -gt "800" ]; then
		nome_temporario=$nome_arq'_temp'
		if [ "$largura" -gt "800" ]; then
			# Define valor máximo de largura, mantendo a razão de aspecto
			convert -resize "800" $nome_arq $nome_temporario
		elif [ "$altura" -gt "800" ]; then
			# Define valor máximo de altura, mantendo a razão de aspecto
			convert -resize "x800" $nome_arq $nome_temporario
		fi
		# Somente atualizar arquivo se tiver tamanho menor
		tamanho_original=$(du -b $nome_arq | awk -F" " '{print $1}')
		tamanho_novo=$(du -b $nome_temporario | awk -F" " '{print $1}')
		if [ "$tamanho_novo" -lt "$tamanho_original" ]; then
		  mv $nome_temporario $nome_arq
		else
		  rm $nome_temporario
		fi		
	else
		echo "Não redimensionar - largura e altura menores ou iguais que 800px"
	fi
	
	# Atualizar contador
	cont=$((cont+1))
	#exit
done
