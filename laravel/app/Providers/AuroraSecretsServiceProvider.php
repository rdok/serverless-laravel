<?php

namespace App\Providers;

use Aws\SecretsManager\SecretsManagerClient;
use Illuminate\Database\DatabaseManager;
use Illuminate\Support\ServiceProvider;

class AuroraSecretsServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->singleton(SecretsManagerClient::class, function ($app) {
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

        var_dump($rawSecretString);

        $secretString = json_decode($rawSecretString);
        $connection = $secretString->engine;

        config(["database.connections.$connection.password" => $secretString->password]);
        config(["database.connections.$connection.database" => $secretString->dbname]);
        config(["database.connections.$connection.port" => $secretString->port]);
        config(["database.connections.$connection.host" => $secretString->host]);
        config(["database.connections.mysql.host" => 'rdokos-local-serverless-laravel-aurora-aurora-u4fx8qa2bfj4.cluster-czgubnfxrn5c.eu-west-1.rds.amazonaws.com']);
        config(["database.connections.$connection.username" => $secretString->username]);

        /** @var DatabaseManager $dbManager */
        $dbManager = $this->app->make(DatabaseManager::class);
        $dbManager->purge();
        $dbManager->purge('mysql');
    }
}
