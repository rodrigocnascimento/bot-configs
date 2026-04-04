import { tool } from @opencode-aiplugin

export default tool({
  description
    Send a notification message to the user's Telegram. Use this tool to notify the user when a task is completed, when something important happens, or when you need their attention. The message supports Markdown formatting.,
  args {
    message tool.schema
      .string()
      .describe(
        The notification message to send. Supports Telegram Markdown bold, _italic_, `code`, ```pre```
      ),
  },
  async execute(args) {
    const token = process.env.TELEGRAM_BOT_TOKEN
    const chatId = process.env.TELEGRAM_CHAT_ID

    if (!token) {
      return Error TELEGRAM_BOT_TOKEN environment variable is not set. Please set it with your Telegram bot token from @BotFather.
    }
    if (!chatId) {
      return Error TELEGRAM_CHAT_ID environment variable is not set. Please run the get-chat-id script to find your chat ID.
    }

    const url = `httpsapi.telegram.orgbot${token}sendMessage`

    try {
      const res = await fetch(url, {
        method POST,
        headers { Content-Type applicationjson },
        body JSON.stringify({
          chat_id chatId,
          text args.message,
          parse_mode Markdown,
        }),
      })

      const data = (await res.json()) as {
        ok boolean
        description string
        result { message_id number }
      }

      if (data.ok) {
        return `Notification sent successfully (message_id ${data.result.message_id})`
      }

      return `Failed to send notification ${data.description  Unknown error}`
    } catch (error) {
      return `Error sending notification ${error instanceof Error  error.message  String(error)}`
    }
  },
})
