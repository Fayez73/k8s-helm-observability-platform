.PHONY: setup destroy port-forward

setup:
	./scripts/setup.sh

destroy:
	./scripts/destroy.sh

port-forward:
	kubectl port-forward svc/grafana -n monitoring 3000:80
