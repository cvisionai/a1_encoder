# Pulling image

```sh
$> docker pull cvisionai/a1_encoder
```

# Building image

```sh
$> docker build -t cvisionai/a1_encoder .
```

# Running image:
```sh
$>docker run --rm -ti cvisionai/a1_encoder

# Then testing the image: 
$> ./test.sh
```

## Version Notes:

| Docker/tag  | Description                     |
| ----------- | :------------------------------ |
| v0.0.1      | Stable release                  |
| v0.0.2      | - Add av1 support, bento4 executables



