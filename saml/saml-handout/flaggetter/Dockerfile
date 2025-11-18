FROM node:24-slim

RUN useradd -r  nodeuser

WORKDIR /srv
COPY . .

RUN rm private.pem
RUN npm install --omit=dev

USER nodeuser

EXPOSE 3000

CMD ["node", "index.js"]

