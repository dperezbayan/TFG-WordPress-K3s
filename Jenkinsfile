pipeline {
    environment {
        IMAGE = "dperezbayan/wpimagen"
        REPO_URL = "https://github.com/dperezbayan/TFG-WordPress-K3s.git"
        BUILD_DIR = "/home/danieltfg2/TFG-WordPress-K3s"
        KUBE_CONFIG = "/etc/rancher/k3s/k3s.yaml"
        DOCKER_HUB = credentials('dockerhub_credentials')
        GIT_BRANCH = "${git_branch}"
    }

    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  name: buildah-pod
spec:
  containers:
    - name: buildah
      image: docker.io/dperezbayan/buildah:v2
      command: ['cat']
      tty: true
      securityContext:
        privileged: true
      volumeMounts:
        - name: containers
          mountPath: /var/lib/containers
  volumes:
    - name: containers
      emptyDir: {}
"""
        }
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        durabilityHint('PERFORMANCE_OPTIMIZED')
        disableConcurrentBuilds()
    }

    stages {
        stage('Verificar rama') {
            steps {
                script {
                    if (!env.GIT_BRANCH.contains("main")) {
                        currentBuild.result = 'ABORTED'
                        error("Este pipeline solo debe ejecutarse en la rama 'main'")
                    }
                }
            }
        }

        stage('Clonar repositorio') {
            steps {
                git branch: 'main', url: "${REPO_URL}"
            }
        }

        stage('Crear y subir imagen') {
            steps {
                container('buildah') {
                    script {
                        sh "buildah build -t ${IMAGE}:${BUILD_NUMBER} ."
                        withCredentials([
                            usernamePassword(
                                credentialsId: 'dockerhub_credentials',
                                usernameVariable: 'DOCKER_USER',
                                passwordVariable: 'DOCKER_PASS'
                            )
                        ]) {
                            sh "echo \$DOCKER_PASS | buildah login -u \$DOCKER_USER --password-stdin docker.io"
                            sh "buildah push ${IMAGE}:${BUILD_NUMBER} docker://docker.io/${IMAGE}:${BUILD_NUMBER}"
                        }
                    }
                }
            }
        }

        stage('Exportar base de datos') {
    steps {
        sshagent(['VPS_SSH']) {
            sh '''
                mkdir -p ~/.ssh
                ssh-keyscan 192.168.100.1 >> ~/.ssh/known_hosts
                ssh-keyscan 192.168.100.2 >> ~/.ssh/known_hosts
                ssh danieltfg@192.168.100.1 mysqldump -u wordpress -pwordpress wordpress > ~/backup.sql
                scp backup.sql danieltfg2@192.168.100.2:/home/danieltfg2/
            '''
                }
            }
        }

        stage('Desplegar en producción') {
            steps {
                sshagent(['VPS_SSH']) {
                    sh "ssh danieltfg2@192.168.100.2 'cd ${BUILD_DIR} && git pull'"
                    sh "ssh danieltfg2@192.168.100.2 'mysql -u wordpress -pwordpress wordpress < ~/backup.sql'"
                    sh "ssh danieltfg2@192.168.100.2 'kubectl apply -f ${BUILD_DIR}/k3s/ --kubeconfig=${KUBE_CONFIG}'"
                    sh "ssh danieltfg2@192.168.100.2 'kubectl apply -f ${BUILD_DIR}/ingress.yaml --kubeconfig=${KUBE_CONFIG}'"
                }
            }
        }
    }
}

