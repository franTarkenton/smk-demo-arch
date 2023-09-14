# stage 1: use npm to install dependencies into node_modules 
#          directory
FROM node:alpine3.12 AS BUILD_IMAGE

#RUN ls -la / &&  ls -la /srv && mkdir /srv
WORKDIR /srv
COPY ["package.json", "package-lock.json", "./"]

# the package.json file is automatically created, Getting people
# who are creating an SMK app may not have the skills to properly
# edit the file so that http-server is defined as a devdependency
# so using the uninstall as a fallback.
RUN npm install && npm uninstall http-server  

# stage 2: don't need node itself, just need the acutal js files that
#          it insalled. This stage builds from caddy and copied the 
#          dependencies from previous stage
FROM caddy:2.1.1-alpine
WORKDIR /srv

# needed assets needs to be copied as a directory, don't see a way 
# around having these two layers as when add assets to the copy command
# it does not create the directory
ADD  assets /srv/assets
COPY ["index.html", "smk-config.json", "smk-init.js", "/srv/"]
COPY --from=BUILD_IMAGE /srv/node_modules /srv/node_modules


EXPOSE 8888
ENTRYPOINT ["caddy", "file-server", "--listen", ":8888", "." ]