<?php

function dsn2cli(string $dsn): ?string
{
    $url = parse_url($dsn);
    if (empty($url['scheme'])) {
        user_error('No scheme found.', E_USER_ERROR);

        return null;
    }
    switch ($url['scheme']) {
        case 'mysql':
            $cmd = 'mysql';
            foreach ([
                         'host' => '-h',
                         'port' => '-P',
                         'user' => '-u',
                         'pass' => '-p',
                     ] as $urlPart => $cmdOption) {
                if (!empty($url[$urlPart])) {
                    $cmd .= " $cmdOption{$url[$urlPart]}";
                }
            }
            if (!empty($url['path'])) {
                $cmd .= ' '.ltrim($url['path'], '/');
            }

            return $cmd;
        case 'postgresql':
            user_error("DSN can be used directly in command line: psql '$dsn'", E_USER_NOTICE);
            $cmd = 'psql';
            foreach ([
                         'host' => '-h ',
                         'port' => '-p ',
                         'user' => '-U ',
                     ] as $urlPart => $cmdOption) {
                if (!empty($url[$urlPart])) {
                    $cmd .= " $cmdOption{$url[$urlPart]}";
                }
            }
            if (!empty($url['pass'])) {
                $cmd .= ' -W'; // Only force password asking
                user_error('The only way to have a password in the command line is to use a DSN — https://www.postgresql.org/docs/current/app-psql.html#R2-APP-PSQL-CONNECTING', E_USER_WARNING);
            }
            if (!empty($url['path'])) {
                $cmd .= ' '.ltrim($url['path'], '/');
            }

            return $cmd;
        case 'redis':
            user_error("DSN can be used directly in command line: redis-cli -u '$dsn'", E_USER_NOTICE);
            $cmd = 'redis-cli';
            foreach ([
                         'host' => '-h ',
                         'port' => '-p ',
                         'pass' => '-a ',
                     ] as $urlPart => $cmdOption) {
                if (!empty($url[$urlPart])) {
                    $cmd .= " $cmdOption{$url[$urlPart]}";
                }
            }
            if (!empty($url['path'])) {
                $cmd .= '-d '.ltrim($url['path'], '/');
            }

            return $cmd;
        default:
            user_error("'{$url['scheme']}' scheme is not supported or not transformable", E_USER_ERROR);
    }
}
