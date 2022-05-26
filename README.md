# mail-sender-cli

Send plain-text mail quickly by command line.

## Requirements

Only `curl` is required.

## Usage

- Using args.

    ```shell
    ./send.sh \
    --smtp-server smtp.163.com \
    --smtp-port 465 \
    --mail-from abc@163.com \
    # multiple receivers supported
    --mail-to ads@qq.com \
    --mail-to afw@gmail.com \
    --password 'xxx' \
    --subject "This is subject" \
    --body "This is body"
    ```

- Using env.

    ```shell
    SMTP_SERVER=smtp.163.com
    SMTP_PORT=465
    MAIL_FROM=abc@163.com
    PASSWORD=xxx

    ./send.sh --mail-to afw@gmail.com --subject "This is subject" --body "This is body"
    ```