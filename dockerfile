FROM dart:2.19.4-sdk

WORKDIR /app

COPY pubspec.* /app/

RUN dart pub global activate conduit
RUN dart pub get

COPY . .

RUN dart pub get --offline

EXPOSE 2222

ENTRYPOINT [ "dart", "pub", "run", "conduit:conduit", "serve", "--port", "2222" ]