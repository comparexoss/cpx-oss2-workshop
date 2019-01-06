pipeline {
    environment {
        GIT_REPO = "https://github.com/comparexoss/cpx-oss2-workshop.git"
        ACR_LOGINSERVER = "hkkacrregistry.azurecr.io"
        ACR_REPO = 'mstrdevopsworkshop'
        ACR_CRED = credentials('acr-credentials')   
        WEB_IMAGE="${env.ACR_LOGINSERVER}/${env.ACR_REPO}/rating-web"
        API_IMAGE="${env.ACR_LOGINSERVER}/${env.ACR_REPO}/rating-api"
        DB_IMAGE="${env.ACR_LOGINSERVER}/${env.ACR_REPO}/rating-db"
        
    }
  options { 
      disableConcurrentBuilds() 
      timestamps()
      
  }
   parameters {
        booleanParam(defaultValue: true, description: 'set true for automatic approve', name: 'autoApprove')
    }
  agent any
  stages {
      stage('Checkout') {
        steps {
            git url: "${env.GIT_REPO}", branch: 'master'
        }
      }
      stage('Prepare Build Server') {
          steps {   
          ansiblePlaybook( 
                playbook : 'playbooks/installprereqonbuildserver.yaml',
                become: true)
        }
      }
      stage('Plan AKS using terraform') {
          steps {   
             dir('terraform')
             {
              script {
                    currentBuild.displayName = "${env.BUILD_TAG}"
                }
              sh 'terraform init -input=false'
              sh "terraform plan -input=false -out tfplan -var 'version=${env.BUILD_NUMBER}'"
              sh 'terraform show -no-color tfplan > tfplan.txt'
             }
        }
      }
      
       stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }

            steps {
                dir('terraform')
                {
                script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                        parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
                }
            }
        }
      
       stage('Apply') {
            steps {
                dir('terraform')
                {
                sh "terraform apply -input=false tfplan"
                }
            }
        }
      
      stage('Build images') {
            steps{
                dir('app/api')
                {
                    script{
                    docker.build("${env.API_IMAGE}:${env.BUILD_NUMBER}")
                    }
                }
                dir('app/web')
                {
                   sh "sudo docker build --build-arg BUILD_DATE=`date '+%Y-%m-%dT%H:%M:%SZ'` --build-arg VCS_REF=`git rev-parse --short HEAD` --build-arg IMAGE_TAG_REF=${env.BUILD_NUMBER} -t ${env.WEB_IMAGE}:${env.BUILD_NUMBER} ."
                }
                dir('app/db')
                {
                    script{
                    docker.build("${env.DB_IMAGE}:${env.BUILD_NUMBER}")
                    }
                }
            }
       }
      stage('Test api image') {
         agent { docker "${env.API_IMAGE}:${env.BUILD_NUMBER}" } 
               steps {
                        sh 'echo $HOSTNAME'
                     }
        }
      
       stage('Test web image') {
         agent { docker "${env.WEB_IMAGE}:${env.BUILD_NUMBER}" } 
               steps {
                        sh 'echo $HOSTNAME'
                     }
      }
      
        stage('Test mongo image') {
         agent { docker "${env.DB_IMAGE}:${env.BUILD_NUMBER}" } 
               steps {
                        sh 'echo $HOSTNAME'
                     }
      }
    stage('Push images to ACR') {
        steps{
            withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'acr-credentials',usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
            sh "docker login ${env.ACR_LOGINSERVER} -u $USERNAME -p $PASSWORD"
            sh "docker push ${env.API_IMAGE}:${env.BUILD_NUMBER}"
            //sh "docker tag ${env.API_IMAGE}:${env.BUILD_NUMBER} ${env.API_IMAGE}:latest"
            //sh "docker push ${env.API_IMAGE}:latest"
            sh "docker login ${env.ACR_LOGINSERVER} -u $USERNAME -p $PASSWORD"
            sh "docker push ${env.WEB_IMAGE}:${env.BUILD_NUMBER}"
            //sh "docker tag ${env.WEB_IMAGE}:${env.BUILD_NUMBER} ${env.WEB_IMAGE}:latest"
            //sh "docker push ${env.WEB_IMAGE}:latest"
            sh "docker login ${env.ACR_LOGINSERVER} -u $USERNAME -p $PASSWORD"
            sh "docker push ${env.DB_IMAGE}:${env.BUILD_NUMBER}"
            //sh "docker tag ${env.DB_IMAGE}:${env.BUILD_NUMBER} ${env.DB_IMAGE}:latest"
            //sh "docker push ${env.DB_IMAGE}:latest"
            }
        }
    }
    stage('Helm PreSteps'){
          steps{
            sh 'sudo /usr/local/bin/helm init --client-only --kubeconfig ~/.kube/config' 
          }
    }
    stage('Deploy using Helm') {
        steps{
               dir('app')
               {
                   sh "sudo /usr/local/bin/helm upgrade --install dbhelmdb ./dbchart/ --kubeconfig ~/.kube/config --set dbserver.image.repo=${env.DB_IMAGE} --set dbserver.image.tag=${env.BUILD_NUMBER}"
                   sh "sudo /usr/local/bin/helm upgrade --install webapihelmd ./webapichart/ --wait --kubeconfig ~/.kube/config --set webserver.image.repo=${env.WEB_IMAGE} --set webserver.image.tag=${env.BUILD_NUMBER} --set apiserver.image.repo=${env.API_IMAGE} --set apiserver.image.tag=${env.BUILD_NUMBER}"
               }
        }
    }
  
  
  }
    
    post {
        always {
            archiveArtifacts artifacts: 'terraform/tfplan.txt'
        }
    }
}
