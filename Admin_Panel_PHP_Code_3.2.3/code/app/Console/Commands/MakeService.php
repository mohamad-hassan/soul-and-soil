<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

class MakeService extends Command
{
    protected $signature = 'make:service {name}';
    protected $description = 'Create a new service class';

    public function handle()
    {
        $name = $this->argument('name');
        $path = app_path("Services/{$name}.php");

        // Check if the service already exists
        if (File::exists($path)) {
            $this->error('Service already exists!');
            return;
        }

        // Create Services directory if it doesn't exist
        File::ensureDirectoryExists(app_path('Services'));

        // Generate the service file
        File::put($path, $this->getStub($name));
        $this->info("Service created successfully: {$name}");
    }

    protected function getStub($name)
    {
        return <<<EOT
<?php

namespace App\Services;

class {$name}
{
    public function handle()
    {
        // Your service logic here
    }
}
EOT;
    }
}