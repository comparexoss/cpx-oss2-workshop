#!/bin/bash
MYPATH="/usr/local/bin/"
sudo /usr/local/bin/kubectl create serviceaccount --namespace kube-system tiller
sudo /usr/local/bin/kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
sudo /usr/local/bin/kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
sudo /usr/local/bin/helm init --service-account tiller
