FROM node:20.17.0

WORKDIR /usr/src/app

COPY package.json package-lock.json* ./

RUN npm install --production

RUN npm install -g serve

COPY build /usr/src/app/build

EXPOSE 3000

CMD ["serve", "-s", "build", "-l", "3000"]
