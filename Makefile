PROJECT = guardduty-jira
FUNCTION = $(PROJECT)
REGION = us-east-1
IAMROLE = arn:aws:iam::947365572083:role/LambdaBasic

.phony: clean

clean:
	rm -f -r $(FUNCTION)*
	rm -f -r site-packages
	rm -f -r src/*.pyc
	rm -f -r src/__pycache__

build-dev: clean
	cd src; zip -r ../$(FUNCTION)-dev.zip . -x "*.git*" "tests/*";\
	cd ..; mkdir -p site-packages
	virtualenv $(FUNCTION)-dev
	. $(FUNCTION)-dev/bin/activate; pip install -r requirements.txt;\
	cd site-packages; cp -r $$VIRTUAL_ENV/lib/python3.6/dist-packages ./;\
	cd dist-packages; zip -r9 ../../$(FUNCTION)-dev.zip . -x "*pip*" "*setuptools*";\

create-dev:
	aws lambda create-function \
		--handler main.lambda_handler \
		--function-name $(FUNCTION)-dev \
		--region $(REGION) \
		--zip-file fileb://$(FUNCTION)-dev.zip \
		--role $(IAMROLE) \
		--runtime python3.6 \
		--timeout 120 \
		--memory-size 512 \

update-dev:
	aws lambda update-function-code \
		--function-name $(FUNCTION)-dev \
		--zip-file fileb://$(FUNCTION)-dev.zip \
		--publish \

delete-dev:
	aws lambda delete-function --function-name $(FUNCTION)-dev
