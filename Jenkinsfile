pipeline {
    agent any

    environment {
        // You can set environment variables here or in the Jenkins UI
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        TF_IN_AUTOMATION = 'true'
        // Ensure local tools (like ./terraform) are found in PATH for subsequent stages
        PATH = "${WORKSPACE}:${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install and Run Terraform') {
            steps {
                script {
                    // Check if terraform is globally available
                    def exists = sh(script: 'command -v terraform', returnStatus: true) == 0
                    if (!exists) {
                        echo "Terraform not found. Proceeding with installation..."
                        // Ensure the script is executable
                        sh 'chmod +x ./install_and_run_terraform.sh'
                        // Run the script
                        sh './install_and_run_terraform.sh'
                    } else {
                        echo "Terraform is already installed. Skipping installation script."
                        sh 'terraform --version'
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                // Wait for manual approval before applying
                input message: 'Do you want to apply changes?', ok: 'Apply'
                
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    // Ask user whether to destroy resources
                    def action = input(
                        message: 'Do you want to destroy the resources?',
                        parameters: [choice(name: 'Action', choices: ['Destroy', 'Keep'], description: 'Choose whether to destroy resources')]
                    )
                    
                    if (action == 'Destroy') {
                        // Attempt to locate and run terraform destroy
                        sh '''
                            # Add current directory to PATH in case terraform installed there
                            export PATH=$PATH:$(pwd)
                            if [ -f "./terraform" ]; then
                                chmod +x ./terraform
                            fi
                            
                            echo "Destroying resources..."
                            terraform destroy -auto-approve
                        '''
                    } else {
                        echo "Resources kept. Skipping destroy."
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

