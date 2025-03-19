pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS = 'Azure-jenkins-sp'
        TF_STATE_RG = 'jenkins-test-rg' 
        TF_STATE_STORAGE = 'tfstatestorage452523532'
        TF_STATE_CONTAINER = 'tfstate' 
    }
    

    stages {
        stage('Checkout') {
            steps {
                sh 'echo "Checking out the code from the repository."'
                git branch: 'main', url: 'https://github.com/SaiAnilKumarDeyyala/azure-terraform-jenkins-automation.git' 
            }
        }

        stage('Deploy Terraform State Storage') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS, subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID', clientIdVariable: 'AZURE_CLIENT_ID', clientSecretVariable: 'AZURE_CLIENT_SECRET', tenantIdVariable: 'AZURE_TENANT_ID')]) {
                    script {
                        sh '''
                            chmod +x init.sh
                            ./init.sh
                        ''' 
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS, subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID', clientIdVariable: 'AZURE_CLIENT_ID', clientSecretVariable: 'AZURE_CLIENT_SECRET', tenantIdVariable: 'AZURE_TENANT_ID')]) {
                    sh '''
                        az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
                        terraform init -backend-config="resource_group_name=$TF_STATE_RG" -backend-config="storage_account_name=$TF_STATE_STORAGE" -backend-config="container_name=$TF_STATE_CONTAINER" -backend-config="key=terraform.tfstate"
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS, subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID', clientIdVariable: 'AZURE_CLIENT_ID', clientSecretVariable: 'AZURE_CLIENT_SECRET', tenantIdVariable: 'AZURE_TENANT_ID')]) {
                    sh '''
                        terraform plan -out=tfplan
                    '''
                }
                archiveArtifacts artifacts: 'tfplan'
            }
        }

        stage('Manual Approval') {
            steps {
                input message: 'Approve Terraform Plan?'
            }
        }

        stage('Manual Approval - Apply or Destroy') {
            steps {
                script {
                    def userChoice = input(
                        message: 'Choose Terraform Action to Perform',
                        parameters: [
                            choice(
                                name: 'ACTION',
                                choices: ['Apply', 'Destroy'],
                                description: 'Choose whether to apply or destroy the Terraform plan'
                            )
                        ]
                    )

                    if (userChoice == 'Apply') {
                        echo "User chose to Apply the Terraform plan."
                        sh '''
                            terraform apply tfplan
                        '''
                    } else if (userChoice == 'Destroy') {
                        echo "User chose to Destroy the Terraform plan."
                        sh '''
                            terraform destroy -auto-approve
                            // post destroy clean up
                            echo "Cleaning up the Terraform state storage resources."
                            az group delete -n $TF_STATE_RG -y
                        '''
                    }
                }
            }
        }

    }
}