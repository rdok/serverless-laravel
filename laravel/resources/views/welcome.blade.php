<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="author" content="Rizart Dokollari">
    <title>AWS SAM - Laravel</title>

    <link rel="stylesheet" href="{{ mix('/css/app.css') }}"/>
</head>
<body class="main-content">
<header>
    <h1>Serverless Laravel</h1>
</header>

<a href="https://github.com/rdok/serverless-laravel/blob/1d29230cce06c4e956bfaaaefb4260b830363ed6/laravel/resources/views/welcome.blade.php#L17">
    <img
        style="border: 1px solid #555; width: 100%"
        src="{{ asset('img/infrastructure.jpg') }}"
        alt="Infrastructure Design for AWS SAM Laravel"
    />
</a>

<hr>

<a href="https://github.com/rdok/serverless-laravel/blob/1d29230cce06c4e956bfaaaefb4260b830363ed6/laravel/resources/views/welcome.blade.php#L29">
    <img
        style="width: 100%"
        src="data:image/jpg;base64,{!!  base64_encode(Storage::get('showcase-storage-retrieval.jpg')) !!}"
        alt="Showcase getting file from storage."/>
</a>

<script src="{{ mix('/js/app.js') }}"></script>
</body>
</html>
