FROM node:16.17.1-alpine3.16@sha256:88d9d8da697877a4a771a40e5cbc10a12c2ad959e82f3b0f36ef35635e17f693 as builder

WORKDIR /app
COPY package.json .
COPY package-lock.json .
RUN npm ci --quiet

COPY . .
RUN npm run compile

FROM node:16.17.1-alpine3.16@sha256:88d9d8da697877a4a771a40e5cbc10a12c2ad959e82f3b0f36ef35635e17f693 as final

RUN ["apk", "--no-cache", "upgrade"]

RUN ["apk", "add", "--no-cache", "tini"]

WORKDIR /app
COPY . .
RUN rm -rf ./test
# Copy in compile assets and deps from build container
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/govuk_modules ./govuk_modules
COPY --from=builder /app/public ./public
RUN npm prune --omit=dev

ENV PORT 9000
EXPOSE 9000

ENTRYPOINT ["tini", "--"]

CMD ["npm", "start"]
