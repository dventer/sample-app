function helm_deploy () {
    if [[ $(helm diff upgrade ${APP} charts/${APP} --set image.repository=${REGISTRY}/${APP} --set image.tag=${TAG}) ]]
    then
        helm upgrade --install ${APP} charts/${APP}	--set image.repository=${REGISTRY}/${APP} --set image.tag=${TAG}
    else
        echo "There's no change in deployment..."
        return 1
}
