PROJECT = guardduty-jira
FUNCTION = $(PROJECT)
REGION = us-east-1
IAMROLE = arn:aws:iam::XXXXXXXXXXX:role/JiraLambda
EVENTRULE = GuardDutyEventRule
EVENTRULEARN = arn:aws:events:us-east-1:XXXXXXXXXXX:rule/GuardDutyEventRule
PYTHONVERSION = python3.6

.phony: clean

clean:
	rm -f -r $(FUNCTION)*
	rm -f -r site-packages
	rm -f -r src/*.pyc
	rm -f -r src/__pycache__

build-dev: clean
	cd src; zip -r ../$(FUNCTION)-dev.zip . -x "*.git*" "tests/*";\
	cd ..; mkdir -p site-packages
	virtualenv -p $(PYTHONVERSION) $(FUNCTION)-dev
	. $(FUNCTION)-dev/bin/activate; pip install -r requirements.txt;\
	cd site-packages; cp -r $$VIRTUAL_ENV/lib/$(PYTHONVERSION)/dist-packages ./;\
	cd dist-packages; zip -r9 ../../$(FUNCTION)-dev.zip . -x "*pip*" "*setuptools*" "*wheel*" "easy_install.py";\

create-dev: build-dev
	$(eval LAMBDAFN := $(shell aws lambda create-function \
		--handler main.lambda_handler \
		--function-name $(FUNCTION)-dev \
		--region $(REGION) \
		--zip-file fileb://$(FUNCTION)-dev.zip \
		--role $(IAMROLE) \
		--runtime $(PYTHONVERSION) \
		--timeout 120 \
		--memory-size 512 | jq .FunctionArn))
	@echo $(LAMBDAFN) 
	aws events put-targets --rule $(EVENTRULE) --targets "Id"="JiraTarget","Arn"=$(LAMBDAFN)
	aws lambda add-permission --function-name $(FUNCTION)-dev \
	    --statement-id gd-event2jira --principal events.amazonaws.com \
	    --action 'lambda:InvokeFunction' \
	    --source-arn $(EVENTRULEARN)

update-dev:
	aws lambda update-function-code \
		--function-name $(FUNCTION)-dev \
		--zip-file fileb://$(FUNCTION)-dev.zip \
		--publish \

delete-dev:
	aws lambda delete-function --function-name $(FUNCTION)-dev
	aws events remove-targets --rule $(EVENTRULE) --ids "JiraTarget"
