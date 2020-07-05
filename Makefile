


master:
	mkdir -p rsrc
	git archive --output rsrc/kubernetes-vagrant-master.tar.gz master



sync:
	rsync -avzP --exclude .vagrant --exclude rsrc/tmp ../kubernetes-vagrant elearning:

up:
	@echo "====> UNSTABLE: no guarantees"
	vagrant status --machine-readable | cut -f2 -d, | sort | uniq | sed '/^$$/d'  | xargs -P10  -I {} vagrant up {} 
