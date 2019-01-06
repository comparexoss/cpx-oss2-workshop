#!/bin/bash
AKSNAME=devopshkkaks
RGNAME=mstrdevopsaksrg
sudo az aks install-cli
sudo az aks get-credentials --resource-group $RGNAME --name $AKSNAME
sudo az aks browse --resource-group $RGNAME --name $AKSNAME
sudo kubectl create serviceaccount --namespace kube-system tiller
sudo kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
sudo kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
sudo helm init --service-account tiller
