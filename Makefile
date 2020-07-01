

sync:
	rsync -avzP --exclude .vagrant --exclude rsrc/tmp ../kubernetes-vagrant hz:


up:
	vagrant status --machine-readable | cut -f2 -d, | sort | uniq | sed '/^$$/d'  | xargs -P10  -I {} vagrant up {} 
