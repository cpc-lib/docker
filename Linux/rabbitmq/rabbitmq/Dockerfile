FROM registry.cn-hangzhou.aliyuncs.com/snow-io/rabbitmq:3.13.3-management

ADD ./rabbitmq_delayed_message_exchange-3.13.0.ez /plugins

# 开启插件
RUN rabbitmq-plugins enable rabbitmq_delayed_message_exchange

ENTRYPOINT ["rabbitmq-server"]