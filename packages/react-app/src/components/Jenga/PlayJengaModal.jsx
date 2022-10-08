import React, { useCallback, useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Button, Card, List, Spin, Popover, Form, Switch, Input, Modal } from "antd";
import { RedoOutlined } from "@ant-design/icons";
import { Address, AddressInput } from "../";
import { ethers } from "ethers";
import { useEventListener } from "eth-hooks/events/useEventListener";


export default function PlayJengaModal({
    writeContracts,
    tx,
    mainnetProvider,
    jengaContract,
    address,
    readContracrs,
    blockExplorer,
    setIsModalVisible,
    isModalVisible,
    updateOneJenga,
    item,
}) {

    const [blocksToRemove, setBlocksToRemove] = useState(0);
    const isOwner = address.toLowerCase() == item.owner ? true : false;
    

    const handleCancel = () => {
        setIsModalVisible(false);
    }

    const handlePlay = async (id, blocks) => {
        try {
            const txCurrent = await tx(writeContracts[jengaContract].play(id, blocks));
            await txCurrent.wait();
            updateOneJenga(id);
        } catch (e) {
            console.log("Play error: ", e);
        }
    }

    return (
        <>
            <Modal 
                title={isOwner ? "Play if you think it's worth it ;)" : `Jenga #${item.id}`}
                visible={isModalVisible}
                onCancel={handleCancel}
                footer={[
                    <Button key="back" onClick={handleCancel}>
                        Cancel
                    </Button>,
                    <Button key="submit" type="primary" onClick={handlePlay(item.id, blocksToRemove)}>
                        Play
                    </Button>
                ]}
            >
                <div style={{ display: "flex", flexDirection: "column", gap: "1rem" }}>
                    <img src={item.image && item.image} alt={"Jenga #" + id} width="150" />

                    <div style={{ width: "90%" }}>
                        <InputNumber
                        style={{ width: "100%" }}
                        placeholder="Number of blocks to remove"
                        value={blocksToRemove}
                        onChange={setBlocksToRemove}
                        />
                    </div>

                </div>
            </Modal>

        </>
    )


}
