pipeline {
  agent any

  environment {
    AWS_ACCOUNT_ID = '<ACCOUNT_ID>'
    AWS_REGION     = 'us-east-1'
    CLUSTER        = 'techpathway-cluster'
    BACKEND_SVC    = 'techpathway-backend-service'
    FRONTEND_SVC   = 'techpathway-frontend-service'
    ECR_BACKEND    = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/techpathway-backend"
    ECR_FRONTEND   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/techpathway-frontend"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build images') {
      steps {
        script {
          env.IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.substring(0, 8)}"
        }
        sh 'docker build --platform linux/amd64 -t techpathway-backend:latest backend'
        sh 'docker build --platform linux/amd64 -t techpathway-frontend:latest frontend'
      }
    }

    stage('Push to ECR') {
      steps {
        sh '''
          aws ecr get-login-password --region $AWS_REGION | \
          docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
        '''
        sh 'docker tag techpathway-backend:latest $ECR_BACKEND:$IMAGE_TAG'
        sh 'docker tag techpathway-frontend:latest $ECR_FRONTEND:$IMAGE_TAG'
        sh 'docker push $ECR_BACKEND:$IMAGE_TAG'
        sh 'docker push $ECR_FRONTEND:$IMAGE_TAG'
      }
    }

    stage('Deploy to ECS') {
      steps {
        script {
          def backendImage = "${env.ECR_BACKEND}:${env.IMAGE_TAG}"
          def frontendImage = "${env.ECR_FRONTEND}:${env.IMAGE_TAG}"

          sh "cat deploy/backend-task-def.json | sed 's|__IMAGE__|${backendImage}|g' > backend-td.json"
          sh "cat deploy/frontend-task-def.json | sed 's|__IMAGE__|${frontendImage}|g' > frontend-td.json"

          def backendTd = sh(
            script: "aws ecs register-task-definition --cli-input-json file://backend-td.json --query 'taskDefinition.taskDefinitionArn' --output text",
            returnStdout: true
          ).trim()

          def frontendTd = sh(
            script: "aws ecs register-task-definition --cli-input-json file://frontend-td.json --query 'taskDefinition.taskDefinitionArn' --output text",
            returnStdout: true
          ).trim()

          sh "aws ecs update-service --cluster ${env.CLUSTER} --service ${env.BACKEND_SVC} --task-definition ${backendTd}"
          sh "aws ecs update-service --cluster ${env.CLUSTER} --service ${env.FRONTEND_SVC} --task-definition ${frontendTd}"

          sh "aws ecs wait services-stable --cluster ${env.CLUSTER} --services ${env.BACKEND_SVC} ${env.FRONTEND_SVC}"
        }
      }
    }
  }

  post {
    success {
      echo "Deployed frontend + backend (tag ${env.IMAGE_TAG}). URL: http://<ALB_DNS_NAME>"
    }
    failure {
      echo "Pipeline failed."
    }
  }
}
