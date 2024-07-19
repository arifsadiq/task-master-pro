pipeline {
    agent any
    
    tools {
        maven 'maven3'
    }
    
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git 'https://github.com/arifdevopstech/task-master-pro.git'
            }
        }
        
        stage('Compile the code') {
            steps {
                sh 'mvn compile'
            }
        }
        
        stage('Trivy FS scan') {
            steps {
                sh 'trivy fs --format table -o fs-report.html .'
            }
        }
        
        stage('Code Quality Check') {
            steps {
                withSonarQubeEnv('sonar') {
                  sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectKey=taskmasterpro -Dsonar.projectName=taskmasterpro \
                  -Dsonar.java.binaries=target '''
                }
            }
        }
        
        stage('Build the Application') {
            steps {
                sh 'mvn package'
            }
        }
        
        stage('Publish the artifact to Nexus') {
            steps {
                withMaven(globalMavenSettingsConfig: 'globalsettings', jdk: '', maven: 'maven3', mavenSettingsConfig: '', traceability: true) {
                  sh 'mvn deploy'
                }
            }
        }
        
        stage('Build and Tag Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                      sh 'docker build -t ari786/taskmasterpro:latest .'
                    }
                }
            }
        }
        
        stage('Docker Image Scan') {
            steps {
                sh 'trivy image --format table -o image-report.html ari786/taskmasterpro:latest'
            }
        }
        
        stage('Push Image to dockerhub') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                      sh 'docker push ari786/taskmasterpro:latest'
                    }
                }
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: ' task-master-pro-cluster', contextName: '', credentialsId: 'k8s-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://1D451579A5DAA17A4371515B8FAA60B8.yl4.us-east-2.eks.amazonaws.com') {
                      sh 'kubectl apply -f deployment-service.yml -n webapps'
                      sleep 30
                }
            }
        }
        
        stage('Verify the deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: ' task-master-pro-cluster', contextName: '', credentialsId: 'k8s-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://1D451579A5DAA17A4371515B8FAA60B8.yl4.us-east-2.eks.amazonaws.com') {
                      sh 'kubectl get pods -n webapps'
                      sh 'kubectl get svc -n webapps'
                }
            }
        }
    }
}
