INPUTS=inputs
BLUEPRINT=blueprint.yaml
DEPLOYMENT=fabric-test

.PHONY: cfy cfm clean

resources/ssh/id_rsa:
	mkdir -p resources/ssh/
	ssh-keygen -N '' -f resources/ssh/id_rsa

cfy: $(BLUEPRINT) $(INPUTS).yaml resources/ssh/id_rsa
	cfy profiles use local
	cfy install $(BLUEPRINT) -i $(INPUTS).yaml --install-plugins

cfm: $(BLUEPRINT) $(INPUTS)-manager.yaml resources/ssh/id_rsa
	cfy blueprints upload -b $(DEPLOYMENT) $(BLUEPRINT)
	cfy deployments create -b $(DEPLOYMENT) -i $(INPUTS)-manager.yaml $(DEPLOYMENT)
	cfy executions start -d $(DEPLOYMENT) --include-logs --timeout 60 install 

cfm-clean:
	-cfy executions list -d $(DEPLOYMENT) | grep started | awk -F'|' '{ print $$2 }' | xargs -n1 --no-run-if-empty cfy executions cancel -f
	-cfy deployments delete -f $(DEPLOYMENT)
	cfy blueprints delete $(DEPLOYMENT)
