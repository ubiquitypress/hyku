module DataCiteCrossrefClientHelpers

  def stub_request_datacite_client1(datacite_client_1, json_data)
    stub_request(:get, "https://api.datacite.org#{datacite_client_1.path}").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: json_data, headers: {'Content-Type'=>'application/json; charset=utf-8'})
  end

  def stub_request_datacite_client2(datacite_client_2, json_data)
    stub_request(:get, "https://api.datacite.org#{datacite_client_2.path}").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: json_data, headers: {'Content-Type'=>'application/json; charset=utf-8'})
  end

  def stub_request_crossref_client1(crossref_client_1, json_data)
    stub_request(:get, "https://api.crossref.org#{crossref_client_2.path}").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: json_data, headers: {'Content-Type'=>'application/json; charset=utf-8'})
  end

  def stub_request_crossref_client2(crossref_client_2, json_data)
    stub_request(:get, "https://api.crossref.org#{crossref_client_2.path}").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: json_data, headers: {'Content-Type'=>'application/json; charset=utf-8'})
  end


end
