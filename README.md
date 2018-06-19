Auto Cut a JIRA ticket from AWS GuardDuty findings

## What?
You're using serverless threat detection, why not serverlessly update your JIRA too?

## Requirements
1. guardduty-jira uses AWS Secrets Manager to store the JIRA user that auto-cuts tickets,
to use this solution you'll need a Secrets Manager secret with three keys:
* user --the user that will be auto cutting the tickets
* password --is that user's password
* endpoint --is the base url of your JIRA server

2. You'll need an IAM role for the Lambda function to assume that has permissions
to read your secret and to write logs to cloudwatch.  Here is an idea of what that role
should look like:

```
{
    "Version": "2012-10-17",
    "Statement": [
            {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Sid": "GetTheSecret",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:us-east-1:XXXXXXXXXXXX:secret:dev/jira/guardduty-bot-nyNj6w"
        }
    ]
}
```

Once you have created the role update _guardduty-jira/Makefile_ to match the arn of the IAM role you created

## 

1. Fork this project into your account and clone into local directory
  ``` bash 
  git clone git@github.com:<your_github_handle>/guardduty-jira.git
  ```

2. Update the configs.yml 
## What again?:
  * jira_project -- your jira project
  * issuetype -- an existing issue type from your jira
  * region -- the region that your secret exists in
  * secret_name -- the name of your AWS Secrets Manager secret

3. Use the Makefile to download the dependencies and build the lambda deployment artifact
  ``` bash
  make build-dev
  ```  

4. Deploy!
  ``` bash
  make create-dev
  ```
