### Description

Provision an AWS Lambda demo function which takes text as input, and returns the text with swapped text case as output.

 - Configured with a function URL, so it can be tested from outside AWS.
 - Input text can be either in the request body, or in the path.
 - Only "Always free" tier resources are used.

### Manual deployment
- Provision an AWS user for terraform with sufficient privileges: [ AWSLambda_FullAccess, CloudWatchLogsFullAccess, IAMFullAccess ]
- Generate access key and secret for the user
- Put credentials into `AWS_ACCESS_KEY_ID` , `AWS_SECRET_ACCESS_KEY` env variables
- Change region in main.tf if it's not `us-east-1`
- Run:     `terraform apply`
- The function name and its provisioned URL will be printed in the console.

### Usage
When input text in the path:

    curl -s <function_url>/HitMeHard

When input text in the body:

    curl -s <function_url> -d 'HitMeHard'

 Response:

     hITmEhARD

### GitHub actions
- pylint: Run pylint on the Python code

### TODO
- Add security vulnerabilities scan (CodeQL) GitHub action
- Add unit tests & GitHub action
- Add TF deployment as GitHub action
- Add deployment verification (curl) as GitHub action
