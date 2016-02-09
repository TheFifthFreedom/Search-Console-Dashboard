require 'pg'
require 'date'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '1d', :first_in => 0 do |job|
  devices_counts = [] # List of devices counts
  desktop_count = 0 # Number of desktop devices
  mobile_count = 0 # Number of mobile devices
  tablet_count = 0 # Number of tablet devices

  values_by_date = Hash.new # Total clicks/impressions per day
  clicks_series = [] # List of clicks data points for the Clicks/Impressions Line Graph
  impressions_series = [] # List of impressions data points for the Clicks/Impressions Line Graph
  ci_line = [] # Clicks/Impressions line

  total_clicks = 0 # Total number of clicks
  total_impressions = 0 # Total number of impressions

  average_ctr = 0 # Average CTR
  ctr_count = 0 # CTR count (to average the CTR sum)

  average_position = 0 # Average position
  position_count = 0 # Position count (to average the position sum)

  # DB connection
  conn = PG.connect( host: '172.16.190.19', port: 5439, dbname: 'gsc', user: 'gscuser', password: 'Gsc@BT2015')

  # Retrieving the 'pages' table (once)
  conn.exec("SELECT * FROM www_ralphlauren_com.pages") do |result|
    result.each do |row|
      # Every column value
      date = DateTime.parse(row.values_at('date')[0]).to_time.to_i
      page = row.values_at('page')[0]
      country = row.values_at('country')[0]
      device = row.values_at('device')[0]
      search_type = row.values_at('search_type')[0]
      clicks = row.values_at('clicks')[0].to_i
      impressions = row.values_at('impressions')[0].to_i
      ctr = row.values_at('ctr')[0].to_f
      position = row.values_at('position')[0].to_f

      # Incrementing the devices counts
      if device == "DESKTOP"
        desktop_count += 1
      elsif device == "MOBILE"
        mobile_count += 1
      else
        tablet_count += 1
      end

      # Computing the total clicks/impressions per day
      if values_by_date.has_key?(date)
        values_by_date[date][0] = values_by_date[date][0] + clicks
        values_by_date[date][1] = values_by_date[date][1] + impressions
      else
        values_by_date[date] = [clicks, impressions]
      end

      # Incrementing the total number of clicks
      total_clicks += clicks
      # Incrementing the total number of impressions
      total_impressions += impressions
      # Incrementing the average CTR
      average_ctr += ctr
      ctr_count += 1
      # Incrementing the average position
      average_position += position
      position_count += 1
    end
    # Setting up the total devices counts
    devices_counts = [
      { label: "Desktop", value: desktop_count },
      { label: "Mobile", value: mobile_count },
      { label: "Tablet", value: tablet_count }
    ]

    # Setting up the clicks/impressions per day line graph
    values_by_date.each do |key, value|
      clicks_series.push({x: key, y: value[0]})
      impressions_series.push({x: key, y: value[1]})
    end
    ci_line = [
        {
            name: "Clicks",
            data: clicks_series
        },
        {
            name: "Impressions",
            data: impressions_series
        }
    ]

    # Averaging the CTR
    average_ctr = (average_ctr / ctr_count).round(2)
    # Averaging the position
    average_position = (average_position / position_count).round(2)
  end

  # Pushing values to dashboard
  send_event('clicks', { current: total_clicks })
  send_event('impressions', { current: total_impressions })
  send_event('ctr', { current: average_ctr })
  send_event('position', { current: average_position })
  send_event('devices', { value: devices_counts })
  send_event('ci_line', series: ci_line)
end
