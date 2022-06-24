# AWS serverless infrastructure for PHP Laravel applications
## Description
Programmatically create the AWS serverless infrastructure for a PHP Laravel application using Terraform.

# Credits
Thanks to Bref for providing the [AWS Lambda layers for PHP](https://bref.sh/docs/runtimes/#lambda-layers-in-details).

# Deploy a demo application
## Create the Terraform project folder
1. Use `examples/simple-app` as root folder for your new application and include the `terraform-aws-serverless-bref` inside the `modules` folder. E.g.:
    ```
    cp -r ~/code/terraform-aws-serverless-bref/examples/simple-app ~/code
    cd ~/code/simple-app
    mkdir modules
    cd modules
    cp -r ~/code/terraform-aws-serverless-bref .
    ```
1. Change directory to the `artifact` folder:
    ```
    cd ~/code/simple-app/artifact
    ```

## Clone the Git repository
1. Create a new or copy an existing Laravel application inside the `artifact` folder:
    ```
    composer create-project laravel/laravel example-app
    cd example-app
    ```
## Build the application
1. Install the Javascript dependecies:
    ```
    npm install
    npm build
    ```

1. Generate the app key:
    ```
    php artisan key:generate
    ```

1. Include the [Bref](https://bref.sh/docs/frameworks/laravel.html) packages:
    ```
    composer require bref/bref bref/laravel-bridge --update-with-dependencies
    ```

1. Clear the Laravel application cache:
    ```
    php artisan config:clear
    ```

## Build the artifact
1. Compress the application in an archive:
    ```
    zip -r ../simple-app.zip . -x 'node_modules/*' 'public/storage/*' 'resources/assets/*' 'storage/*' 'tests/*'
    ```
    > If you want to exclude additional directories or files, add their patch after the `-x` argument.

1. Create a checksum for the archive:
    ```
    cd ~/code/simple-app/artifact
    openssl dgst -sha256 -binary simple-app.zip | openssl enc -base64 > simple-app.zip.sha256
    ```

## Configure the Terraform module
1. Create the `terraform.tfvars` file:
    ```
    cd ~/code/simple-app/
    cp terraform.tfvars.example terraform.tfvars
    ```

1. Edit the `terraform.tfvars` file:
    ```
    vi terraform.tfvars
    ```

    > Please, make sure to use the [AWS Lambda layers](https://runtimes.bref.sh/) matching version of the `bref/bref` PHP package for the exact region you are provisioning the infrastructure to.

## Provision the infrastrure and deploy the application
1. Initate Terraform:
    ```
    terraform init
    ```

1. Preview the infrastructure:
    ```
    terraform plan
    ```

1. Create the infrastructure:
    ```
    terraform apply
    # Review and respond with "yes"
    ```