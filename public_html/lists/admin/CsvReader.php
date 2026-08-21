<?php

class CsvReader
{
    private $fh;
    private $delimiter;
    private $totalRows;

    const ENCLOSURE = '"';
    const ESCAPE = "\0";

    /**
     * Constructor.
     * Normalise record separators because PHP 8.2 no longer supports
     * auto_detect_line_endings. CR characters inside enclosed fields are kept.
     * Read all rows from the file to get the count of rows ignoring empty lines.
     */
    public function __construct($filename, $delimiter)
    {
        $this->fh = $this->normalisedStream($filename);
        $this->delimiter = $delimiter;
        $this->totalRows = 0;

        while ($row = fgetcsv($this->fh, 0, $this->delimiter, self::ENCLOSURE, SELF::ESCAPE)) {
            if ($row[0] !== null) {
                ++$this->totalRows;
            }
        }
        rewind($this->fh);
    }

    /**
     * Copy a CSV file to a temporary stream while normalising CR and CRLF
     * record separators to LF. The temporary stream spills to disk after 5 MB.
     *
     * @return resource
     */
    private function normalisedStream($filename)
    {
        $source = fopen($filename, 'rb');
        if ($source === false) {
            throw new RuntimeException('Unable to open CSV file');
        }

        $stream = fopen('php://temp/maxmemory:5242880', 'w+b');
        if ($stream === false) {
            fclose($source);
            throw new RuntimeException('Unable to create CSV temporary stream');
        }

        $insideEnclosure = false;
        $previousWasRecordCr = false;

        while (!feof($source)) {
            $chunk = fread($source, 8192);
            if ($chunk === false) {
                fclose($source);
                fclose($stream);
                throw new RuntimeException('Unable to read CSV file');
            }

            $length = strlen($chunk);
            for ($i = 0; $i < $length; ++$i) {
                $character = $chunk[$i];

                if ($character === self::ENCLOSURE) {
                    $insideEnclosure = !$insideEnclosure;
                    $previousWasRecordCr = false;
                    fwrite($stream, $character);
                    continue;
                }

                if (!$insideEnclosure && $character === "\r") {
                    fwrite($stream, "\n");
                    $previousWasRecordCr = true;
                    continue;
                }

                if (!$insideEnclosure && $character === "\n" && $previousWasRecordCr) {
                    $previousWasRecordCr = false;
                    continue;
                }

                $previousWasRecordCr = false;
                fwrite($stream, $character);
            }
        }

        fclose($source);
        rewind($stream);

        return $stream;
    }

    /**
     * Return the number of rows in the file.
     *
     * @return int
     */
    public function totalRows()
    {
        return $this->totalRows;
    }

    /**
     * Return the result of calling fgetcsv() ignoring empty lines.
     *
     * @return array|false|null
     */
    public function getRow()
    {
        do {
            $row = fgetcsv($this->fh, 0, $this->delimiter, self::ENCLOSURE, SELF::ESCAPE);
        } while ($row && $row[0] === null);

        return $row;
    }
}
