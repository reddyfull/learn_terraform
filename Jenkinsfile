pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building..'
                // Here you will put the command to build your project, for example 'npm install' if it's a Node.js project
            }
        }
        stage('Test'){
            steps{
                echo 'Testing..'
                // Here you will put the command to test your project, for example 'npm test' if it's a Node.js project
            }
        }
        stage('Deploy') {
            steps{
                echo 'Deploying....'
                // Here you will put the command to deploy your project. This will depend on your project and where you're deploying
            }
        }
    }
}
