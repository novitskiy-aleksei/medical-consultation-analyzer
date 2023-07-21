# Stage 1: Building the application
FROM ruby:3.0.2 AS Builder

# Set the workdir inside the container
WORKDIR /app

# Add the Gemfile and Gemfile.lock from your app
COPY Gemfile* ./

# Install bundler and the necessary gems
RUN gem install bundler && bundle install

# Copy the rest of your app's source code inside the Docker image
COPY . .

# Stage 2: Running the application
FROM ruby:3.0.2

# Create a directory for the app and use it as the working directory
RUN mkdir /app
WORKDIR /app

# Copy the app from the builder stage
COPY --from=Builder /app /app

# Expose port 3000 to the Docker host, so we can access it from the outside
EXPOSE 3000

# The main command to run when the container starts
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
