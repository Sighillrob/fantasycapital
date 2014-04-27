if Rails.env.production? || Rails.env.development?
  Rails.configuration.stripe = {
    :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
    :secret_key  => ENV['STRIPE_SECRET_KEY']
  }
else
  # Stripe (these are test keys only so they are safe)
  Rails.configuration.stripe = {
    :publishable_key => 'pk_test_BmYJ7lge4AeP0sKdsle7K93A',
   :secret_key => 'sk_test_EYDrd5oqAgSNqb0iynt0khNI'
  }
end
Stripe.api_key = Rails.configuration.stripe[:secret_key]
