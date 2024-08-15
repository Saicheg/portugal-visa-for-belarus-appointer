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

Dir['/attachments/*.pdf'].each { |file| mail.add_file(file) }

timezone = Timezone['Europe/Minsk']
offset =  Rational(timezone.utc_offset / (24 * 60 * 60).to_f)
send_time = DateTime.new(SEND_TIME.year, SEND_TIME.month, SEND_TIME.day, SEND_TIME.hour, SEND_TIME.minute, SEND_TIME.second, offset)

mail.header['Date'] = send_time.strftime('%a, %d %b %Y %H:%M:%S %z')

loop do
  current_time = DateTime.now

  $logger.info("Checking if time has come to send email #{current_time} > #{send_time}")

  if current_time >= send_time
    $logger.info 'Sending email'
    mail.deliver!
    exit(0)
  end

  sleep(0.5)
end
