pipeline {
  agent any
   stages {
    stage ('Build') {
      steps {
        sh '''#!/bin/bash
        cd Application
        python3 -m venv test3
        source test3/bin/activate
        pip install pip --upgrade
        pip install -r requirements.txt
        export FLASK_APP=application
        flask run &
        '''
     }
    }
    stage ('test') {
      steps {
        sh '''#!/bin/bash
        cd Application
        source test3/bin/activate
        py.test --verbose --junit-xml test-reports/results.xml
        ''' 
      }
    
      post{
        always {
          junit 'Application/test-reports/results.xml'
        }       
      }
    }
    stage ('Create Container') {
        agent{label 'DockerDep5'}
        steps {
          sh '''#!/bin/bash
            docker build -t kerrismithkura/deployment5:latest .
          '''
       }
    }
    stage ('Push to Dockerhub') {
        agent{label 'DockerDep5'}
        steps {
         DOCKERHUB_CREDENTIALS=credentials('DockerHubKey')
         sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
         sh '''#!/bin/bash
            docker push kerrismithkura/deployment5:latest
          '''
        }
    }
    stage ('Deploy to ECS init') {
        agent{label 'TerraformDep5'}
        steps {
         withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('intTerraform') {
                              sh 'terraform init' 
                            }
            }
        } 
    }

    stage ('Deploy to ECS plan') {
        agent{label 'TerraformDep5'}
        steps {
         withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('intTerraform') {
                               sh 'terraform plan -out plan.tfplan -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key"'
                            }
            }
        } 
    }

    stage ('Deploy to ECS apply') {
        agent{label 'TerraformDep5'}
        steps {
         withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('intTerraform') {
                               sh 'terraform apply plan.tfplan' 
                            }
            }
        } 
    }
  }
 }

