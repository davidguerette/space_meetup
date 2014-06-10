require 'pry'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/events'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."
end

get '/example_protected_page' do
  authenticate!
end

get '/submit_event' do
  erb :submit_event
end

get '/events' do
  @events = Event.all.sort_by {|event| event.name}
  erb :index
end

get '/' do
  redirect '/events'
end

get '/events/:id' do
  id = params[:id]
  @event = Event.find(id)
  erb :show
end

post '/events/:event_id/attendees' do
  @event = Event.find(params[:event_id])
  @user = session[:user_id]
  Attendee.create(user_id: @user, event_id: @event.id)
  redirect "/events/#{@event.id}"
end

post '/submit_event' do
  Event.create(name: params["event_name"], location: params["location"], description: params["description"])
  event = Event.last
  id = event.id
  redirect "/events/#{id}"
end
