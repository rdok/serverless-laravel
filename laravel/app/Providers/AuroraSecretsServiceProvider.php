<?php

namespace App\Providers;

use Aws\SecretsManager\SecretsManagerClient;
use Illuminate\Support\ServiceProvider;

class AuroraSecretsServiceProvider extends ServiceProvider
{
    public function register()
    {
        $this->app->singleton(SecretsManagerClient::class, function () {
            return new SecretsManagerClient([
                'version' => '2017-10-17',
                'region' => env('AWS_DEFAULT_REGION'),
                'credentials' => [
                    'key' => env('AWS_ACCESS_KEY_ID'),
                    'secret' => env('AWS_SECRET_ACCESS_KEY'),
                    'token' => env('AWS_SESSION_TOKEN'),
                ],
            ]);
        });
    }

    /**
     * Bootstrap any application services.
     *
     * @param SecretsManagerClient $client
     * @return void
     */
    public function boot(SecretsManagerClient $client)
    {
        $auroraSecretARN = env('AURORA_SECRET_ARN');

        if (empty($auroraSecretARN)) return;

        $rawSecretString = $client
            ->getSecretValue(['SecretId' => $auroraSecretARN])
            ->get('SecretString');

        $secretString = json_decode($rawSecretString);
        $connection = $secretString->engine;

        config(["database.connections.$connection.password" => $secretString->password]);
        config(["database.connections.$connection.database" => $secretString->dbname]);
        config(["database.connections.$connection.port" => $secretString->port]);
        config(["database.connections.$connection.host" => $secretString->host]);
        config(["database.connections.$connection.username" => $secretString->username]);
    }
}
