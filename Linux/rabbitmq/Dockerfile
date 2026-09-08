FROM registry.cn-hangzhou.aliyuncs.com/snow-io/rabbitmq:4.1-management

ADD ./rabbitmq_delayed_message_exchange-4.1.0.ez /opt/rabbitmq/plugins/

RUN rabbitmq-plugins enable --offline rabbitmq_delayed_message_exchange \
    && rabbitmq-plugins enable --offline rabbitmq_stomp \
    && rabbitmq-plugins enable --offline rabbitmq_mqtt rabbitmq_web_mqtt

ENTRYPOINT ["rabbitmq-server"]