


prepare:
	sudo vagrant plugin install vagrant-hostmanager
	sudo vagrant plugin install vagrant-sshfs


master:
	mkdir -p rsrc
	git archive --output rsrc/kubernetes-vagrant-master.tar.gz master



sync:
	rsync -avzP --exclude .vagrant --exclude rsrc/tmp ../kubernetes-vagrant elearning:

#up:
#	@echo "====> UNSTABLE: no guarantees"
#	vagrant status --machine-readable | cut -f2 -d, | sort | uniq | sed '/^$$/d'  | xargs -P10  -I {} vagrant up {} 

up:
	(for machine in $$( vagrant status --machine-readable | cut -f2 -d, | sort | uniq | sed '/^$$$$/d' ) ; do \
		vagrant up $$machine --provider libvirt	;							\
	 done)
