#!/usr/bin/env ruby

require 'logger'
require 'mail'
require 'timezone'

$logger = Logger.new(STDOUT)
$logger.level = Logger::DEBUG

module SMTPDebugLogger
  private

  def build_smtp_session
    smtp = super
    smtp.set_debug_output($logger)
    smtp
  end
end

Mail::SMTP.prepend(SMTPDebugLogger)

TO = ENV.fetch('TO_EMAIL')
SUBJECT = ENV.fetch('SUBJECT')
BODY = File.read('body.txt')
SEND_TIME = DateTime.parse(ENV.fetch('SEND_TIME'))
OFFSET_SECONDS = 2

OPTIONS = {
  address: 'smtp.gmail.com',
  port: 587,
  domain: 'gmail.com',
  user_name: ENV.fetch('GMAIL_USERNAME'),
  password: ENV.fetch('GMAIL_PASSWORD'),
  authentication: 'plain',
}

Mail.defaults { delivery_method :smtp, OPTIONS }

mail = Mail.new do
  from    ENV.fetch('GMAIL_USERNAME')
  to      TO
  subject SUBJECT
  body    BODY
end

if ENV['FROM']
  mail.from = ENV['FROM']
end

if ENV['REPLY_TO']
  mail.reply_to = ENV['REPLY_TO']
end

if Dir.exist?('/attachments')
  Dir['/attachments/*.pdf'].each { |file| mail.add_file(file) }
end

timezone = Timezone['Europe/Minsk']
offset =  Rational(timezone.utc_offset / (24 * 60 * 60).to_f)
send_time = DateTime.new(SEND_TIME.year, SEND_TIME.month, SEND_TIME.day, SEND_TIME.hour, SEND_TIME.minute, SEND_TIME.second, offset)
send_time_with_offset = send_time - (OFFSET_SECONDS / (24 * 60 * 60).to_f)

mail.header['Date'] = send_time.strftime('%a, %d %b %Y %H:%M:%S %z')

# NOTE: We don't know if these headers will work, but they worth to try
mail.header['Importance'] = 'High'
mail.header['X-Priority'] = '1'
mail.header['Priority'] = 'Urgent'
mail.header['X-MSMail-Priority'] = 'High'


if DateTime.now >= send_time_with_offset
  $logger.info 'SEND_TIME is in the past. Exiting'
  exit(0)
end

loop do
  current_time = DateTime.now

  $logger.info("Checking if time has come to send email #{current_time} > #{send_time_with_offset}")

  if current_time >= send_time_with_offset
    $logger.info 'Sending email'
    mail.deliver!
    exit(0)
  end

  sleep(0.3)
end
