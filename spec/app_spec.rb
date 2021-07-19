describe "App" do
  it "responds with HTML" do
    # Make a GET request to the server
    get "/"
    # Inspect the body of the response
    expect(last_response.body).to include("<h2>Hello <em>World</em>!</h2>")
  end
end
