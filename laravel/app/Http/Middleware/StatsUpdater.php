<?php

namespace App\Http\Middleware;

use App\Models\Stat;
use Closure;
use Illuminate\Http\Request;

class StatsUpdater
{
    public function handle(Request $request, Closure $next)
    {
        $response = $next($request);

        /** @var Stat $stat */
        $stat = Stat::firstOrNew(['name' => 'website_views']);
        $counter = empty($stat->counter) ? 0 : (int)$stat->counter;
        $counter++;

        $stat->fill(['counter' => $counter])->save();

        return $response;
    }
}
